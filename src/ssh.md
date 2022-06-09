# ssh

Quick and simple SSH guide setup.

## Keys

### Generate private and public keys

Generate ssh keys using `rsa` algorithm with `4096` bits. This will generate the
keys at the `~/.ssh/` directory. For more info check [arch
wiki](https://wiki.archlinux.org/index.php/SSH_keys).

```sh
ssh-keygen -t rsa -b 4096
```

### Copy over ssh keys

#### Using ssh-copy-id

To copy over ssh public key use the following commannd, replace `user` with the
user you're trying to login to and `hostname` with the hostname of the machine,
example: `miku@127.0.0.1`.

```sh
ssh-copy-id user@hostname
```

#### Manually copying over

To manually copy over the ssh public key, cat the public key with this command.
Select the output content and copy.

```sh
cat ~/.ssh/id_rsa.pub
```

`ssh` into the other machine and create/edit the `authorized_keys` file in the
`~/.ssh/` directory. Append the output from the previous instruction into the
`authorized_keys` file and save.

## Connect

With keys generated and public key transfered to the machine you're trying to
the other machine the login process can be login without password with

```
ssh <user>@<hostname>
```

## Forwarding port using SSH

Bind `local` port to `remote` port using ssh as the tunnel. [Read
more](https://wiki.archlinux.org/index.php/OpenSSH#Forwarding_other_ports).

```
ssh -L local-port:127.0.0.1:remote-port user@hostname -N
```

## Config

We can use config to have a short name when ssh to another host. In the
`~/.ssh/` directory create/edit the file with the name `config`. The syntax will
look like this

```
Host <some_name>
    HostName <hostname>
    User <username>
    Port <ssh_port>
```

`<some_name>`: This is the name you're using later when sshing into the machine.
               This can be anything.

`<username>`: The user you're trying to connect as.

`<ssh_port>`: The port ssh you're trying to ssh into. This can be removed and
              it'll use the default port `22`.

Example config

```
Host helloworld
    Hostname example.com
    User miku
    Port 22
```

We can just run ssh like this

```
ssh helloworld
```

## Security

For better security it is recommended that the password login is disabled. To
disable password login edit the file `/etc/ssh/sshd_config` file, find/add
`PasswordAuthentication` and set the value to `no`.

```
PasswordAuthentication no
```

Disable `root` login is also a good idea.

```
PermitRootLogin no
```

## File Transfer

### rsync

```shell
rsync -rvP <source> <destination>
```

### scp

```
scp <sourc> <destination>
```

