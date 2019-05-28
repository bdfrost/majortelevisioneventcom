// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("./prod/majortelevisioneventcom - Prod-104645181c60.json")}"
 project     = "majortelevisioneventcom-prod"
 region      = "us-central1"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "mtv-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "us-central1-a"

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

metadata {
   sshKeys = "bfrost:${file("~/.ssh/id_rsa.pub")}"
}

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

 network_interface {
   network = "default"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

// A variable for extracting the external ip of the instance
output "ip" {
 value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}