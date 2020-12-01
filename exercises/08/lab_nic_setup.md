# Setting up a network connection in the Lab

For this exercise we will require network access to the PYNQ board, so
we include some instructions here to set and verify that the connections
is working.

Consider that not all lab workstations are configured in the same way or
have the same network peripherals, so some of the steps or intermediate
results might vary between different workstations. Remember this if you
resume your work on a different workstation.

## Verify there is a physical Ethernet connection

Some workstations in the lab are already configured so that there is a
Ethernet cable connecting the PYNQ board to the PC: if this is your case
you can skip this section.

If there is no Ethernet cable connected to your PYNQ board, check if
there is another (larger) development board at your workstation.
If there is no other board at your station and there is no Ethernet
cable already connected to your PYNQ board, switch to another
workstation (this condition shouldn't be met in TC219, so check twice!)

If there is another board (it should be an Altera Cyclone V board) there
should be an Ethernet cable connected to it: **memorize what port the
cable is connected to, and REMEMBER to reconnect the Ethernet cable
before leaving the workstation, to avoid disrupting other courses**.

Disconnect such cable from the Altera board and connect it to the PYNQ
Ethernet socket.

If your workstation does not have any network cable going to the
attached PYNQ or Altera board, change workstation (this condition
shouldn't be met in TC219, so check twice!)

## Network addresses

Each workstation in TC219 should come with two physical network
interfaces and two Ethernet cables: one is integrated in the motherboard
and is connected to TUT network, the other is a USB Ethernet dongle,
used for a local connection to the local development boards.

The local connection is a host-to-host direct connection, and on the
Windows side, there is no DHCP server configured on it.
To make the setup simpler and have Internet connectivity from the PYNQ
board, we will connect the USB Ethernet adapter to the VM, which has
been already configured to automatically provide DHCP and NAT for USB
Ethernet Adapters.

We will still need to determine the addresses of the various hosts in
this exercise to verify that the network setup is indeed working and to
complete some of the actual tasks of this exercise.

An IPv4 address is usually represented as four octets interleaved by a
single dot, optionally followed by a "/" and a network prefix in decimal
notation (e.g., in `192.168.0.1/24`, the host address is `192.168.0.1`
and the network prefix is `24` bits long).

### Connect the USB Ethernet Adapter to the VM

Once the VM is running, check the in the VMWare Workstation Menu Bar:
`VM` -> `Removable Devices`

One of the listed devices should be named "USB Ethernet" or "USB LAN",
select `Connect` to connect it to the VM (and disconnect it from the
Windows Host).

### Discover your VM network address

(If you just connected the USB Ethernet adapter to the VM wait a few
seconds for the automatic setup to be completed)

By issuing `ip address` on a terminal window, you should see a list of
interfaces and their addresses.

One of the interfaces should be called `ethUSB00`, and its IPv4 address
should be listed in the line starting with "inet ":

```bash
ip address show dev ethUSB00 | grep "inet "
```
Take a note of this VM address.

### Discover the address of the PYNQ board

The VM should act as a DHCP server for the network connected to the USB
Ethernet adapter, and the custom GNU Linux build that we generate from
Yocto is already setup to use a DHCP client to configure the Ethernet
interface at boot: rebooting the board should be enough to get a fresh
DHCP lease.

If, for debugging, you want to manually trigger the DHCP client without
rebooting, you could simply run `udhcpc` as root on the PYNQ board.

Take a note of the configured IPv4 address by looking at

```bash
ip address show dev eth0
```

You should also be able to verify that a gateway and a DNS server
address have been automatically configured:

```bash
ip route | grep default # This should match the VM IP address from the previous section
cat /etc/resolv.conf
```

At the end of this step you should have written down:

VM IP: `<ip_vm>/<prefix>`
PYNQ IP: `<ip_pynq>/<prefix>`

Both IPs should differ only in the last octet, and they should be
configured to have exactly the same network prefix length.

## Testing it works

To make sure everything is actually working and that the VM and the
PYNQ board can communicate with each other over the network you can
follow these steps:

### From VM to PYNQ

On the VM, open a terminal and type:

```sh
student@VM> ping -c4 <ip_pynq>
```

you should expect all four sent packets to be correctly acknowledged with
an RTT of at most a few ms.

### From PYNQ to VM

On the PYNQ board, logging as `root` in the serial console through
PuTTY, type:

```sh
root@PYNQ> ping -c4 <ip_vm>
```

you should expect the same kind of RTT recorded above, and all four
requests to be correctly acknowledged.

### From PYNQ to the World

The VM should be already configured with a NAT, so if everything up to
this point was working you should be able to reach the Internet from the
PYNQ board, going through the VM NAT, and receive replies.

From the serial console on the PYNQ board:

```sh
root@PYNQ> ping -c4 www.google.com
```

once again, you should expect all four requests to be correctly
acknowledged, but with a greater RTT (an order of magnitude greater).

### SSH access to the PYNQ board

Finally, test that you can establish SSH connections from inside the VM
to the PYNQ board:

```bash
student@VM> ssh root@<ip_pynq>
```

(it should log in without a password).


## On mutable SSH server key fingerprints

Be aware that every time the rootfs is rebuilt a new SSH server
keypair is generated for the PYNQ board.

Upon connecting to an unknown (untrusted) server, the SSH client will
ask you to verify the server key fingerprint to ensure trust, and will
then store the ip-fingerprint combination as a record of your trust.

Whenever you connect to the same ip address, but retrieve a different
SSH server public key, not matching the stored fingerprint, the client
will assume something is wrong, and abort the connection.
At screen the client will also show instructions about how to remove
stale server-fingerprint entries from the trust cache: follow them to
be able to establish a connection again.

