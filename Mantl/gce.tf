variable control_count { default = 2 }
variable worker_count { default = 3 }
variable edge_count { default = 1 }
variable short_name { default = "mycluster" }

provider "google" {
  credentials = "${file("~/PhenoMeNal-credentials.json")}"
  project = "phenomenal-1145"
  region = "europe-west1"
}

module "gce-dc" {
  source = "./terraform/gce"
  datacenter = "gce-dc"
  control_type = "n1-standard-1"
  worker_type = "n1-highcpu-2"
  network_ipv4 = "10.0.0.0/16"
  long_name = "phenomenal-development"
  short_name = "${var.short_name}"
  zone = "europe-west1-b"
  control_count = "${var.control_count}"
  worker_count = "${var.worker_count}"
  edge_count = "${var.edge_count}"
}

module "dns" {
  source = "./terraform/gce/dns"
  control_count = "${var.control_count}"
  control_ips = "${module.gce-dc.control_ips}"
  domain = "ph.farmbio.uu.se"  
  edge_count = "${var.edge_count}"
  edge_ips = "${module.gce-dc.edge_ips}"
  short_name = "${var.short_name}"
  subdomain = ".${var.short_name}"
  worker_count = "${var.worker_count}"
  worker_ips = "${module.gce-dc.worker_ips}"
  managed_zone = "phnmnl-uu"
}

