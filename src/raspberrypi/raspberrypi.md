# Raspberry Pi Notes

## docker

Add this to `cmdline.txt` to show memory limit on docker.

```
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

