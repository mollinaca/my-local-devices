
for my local raspberrypi: ubuntu 20.10 Desktop

# prepare

## set up ubuntu 20.10 on raspberrypi4 

* install OS
  * https://ubuntu.com/tutorials/how-to-install-ubuntu-desktop-on-raspberry-pi-4#1-overview
* boot
* network configure
* ssh 

## user password

* set `private.yaml` on this directory
  * e.g. `private.yaml.example` on this directory
* encryption
```
# ansible-vault encrypt private.yaml 
```
 -> require vault password


# apply playbook

```
# ansilbe-playbook -i hosts raspberry1.yaml
```


