# amhello-rpm
build automake sample project as an RPM

To build:
```
$ vagrant up
$ vagrant ssh
[vagrant]$ cd /vagrant
[vagrant]$ make rpm
```
    
This will build the RPM in `~/rpmbuild/RPMS/x86_64`.
    
TODO:
* To build a newer version, update the `Release:` line in
  `amhello.spec` to change the release number.
* We could update the `make atlas` target to copy into tuppum-fs instead.
* Set up a Jenkins job that launches the Vagrant VM (or has the necessary
  build packages installed) and does `make clean rpm atlas`
