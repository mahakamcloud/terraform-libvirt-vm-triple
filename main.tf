resource "libvirt_volume" "vm_volume" {
  name   = "${var.instance_name}"
  pool   = "${var.pool_name}"
  source = "${var.source_path}"
  format = "${var.disk_format}"
}

resource "libvirt_cloudinit" "vm_init" {
  name  = "${var.instance_name}-init.iso"

  user_data = "${var.user_data}"
}

resource "libvirt_domain" "vm_domain" {
  name        = "${var.instance_name}"
  memory      = "${var.memory_size}"
  vcpu        = "${var.num_cpu}"
  autostart   = "${var.autostart}"

  cloudinit = "${libvirt_cloudinit.vm_init.id}"

  network_interface {
    bridge         = "${var.private_network_bridge}"
    hostname       = "${var.instance_name}"
    wait_for_lease = false
  }

  network_interface {
    bridge         = "${var.mahakam_network_bridge}"
  }

  network_interface {
    bridge         = "${var.public_network_bridge}"
    hostname       = "${var.instance_name}"
    mac            = "${var.mac_address}"
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = "${libvirt_volume.vm_volume.id}"
  }
}
