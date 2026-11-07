---
name: Bug report
about: Something doesn't work as expected
title: "[bug] "
labels: bug
---

**What happened / what did you expect?**


**Steps to reproduce**
1.
2.

**Setup**
- Hyprland (`hyprctl version | head -1`):
- Quickshell (`qs --version`):
- Kernel (`uname -r`):
- Machine: laptop / desktop / VM · GPU: yes/no · VNC: yes/no · monitors:

**Diagnostics** (relevant parts only; remove private info)
```
./install.sh --check

hyprctl configerrors

qs log -c kessel | grep -E 'WARN|ERROR|caused' | tail -30
```

**Screenshot / recording** (optional)

<!-- Security issues (lock screen bypass, exposed ports, …): please don't file publicly; contact the maintainer. -->
