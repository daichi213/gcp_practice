resource "google_compute_network" "my_test_daichi_vpc" {
  name                            = "my-test-daichi-vpc"
  description                     = "for testing"
  mtu                             = 1460
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  routing_mode                    = "REGIONAL"
}

# resource "google_compute_subnetwork" "my_test_daichi_public_subnet" {
#   network                    = google_compute_network.my_test_daichi_vpc.id
#   name                       = "my-test-public1"
#   description                = "public subnet"
#   ip_cidr_range              = "10.12.0.0/16"
#   region                     = "asia-northeast1"
#   fingerprint                = null
#   private_ip_google_access   = false
#   private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
# }

resource "google_compute_subnetwork" "my_test_daichi_public_subnet_iowa" {
  network                    = google_compute_network.my_test_daichi_vpc.id
  name                       = "my-test-public1-iowa"
  description                = "public subnet in iowa"
  ip_cidr_range              = "10.20.0.0/16"
  region                     = "us-central1"
  fingerprint                = null
  private_ip_google_access   = false
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
}

resource "google_compute_firewall" "my_test_daichi_vpc_allow_icmp" {
  network        = google_compute_network.my_test_daichi_vpc.id
  name           = "my-test-daichi-vpc-allow-icmp"
  description    = "任意の送信元からネットワーク上の任意のインスタンスへの ICMP 接続を許可します。"
  direction      = "INGRESS"
  disabled       = false
  enable_logging = null
  priority       = 65534
  source_ranges  = ["0.0.0.0/0"]
  allow {
    ports    = []
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "my_test_daichi_vpc_allow_rdp" {
  network        = google_compute_network.my_test_daichi_vpc.id
  name           = "my-test-daichi-vpc-allow-rdp"
  description    = "任意の送信元からネットワーク上の任意のインスタンスへのポート 3389 を使用した RDP 接続を許可します。"
  direction      = "INGRESS"
  disabled       = false
  enable_logging = null
  priority       = 65534
  source_ranges  = ["0.0.0.0/0"]
  allow {
    ports    = ["3389"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "my_test_daichi_vpc_allow_ssh" {
  network        = google_compute_network.my_test_daichi_vpc.id
  name           = "my-test-daichi-vpc-allow-ssh"
  description    = "任意の送信元からネットワーク上の任意のインスタンスへのポート 22 を使用した TCP 接続を許可します。"
  direction      = "INGRESS"
  disabled       = false
  enable_logging = null
  priority       = 65534
  source_ranges  = ["0.0.0.0/0"]
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "my_test_daichi_vpc_allow_http" {
  network        = google_compute_network.my_test_daichi_vpc.id
  name           = "my-test-daichi-vpc-allow-http"
  description    = ""
  direction      = "INGRESS"
  disabled       = false
  enable_logging = null
  priority       = 1000
  source_ranges  = ["0.0.0.0/0"]
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  target_tags = [
    "http-server"
  ]
}

resource "google_compute_firewall" "my_test_daichi_vpc_allow_https" {
  network        = google_compute_network.my_test_daichi_vpc.id
  name           = "my-test-daichi-vpc-allow-https"
  description    = ""
  direction      = "INGRESS"
  disabled       = false
  enable_logging = null
  priority       = 1000
  source_ranges  = ["0.0.0.0/0"]
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }
  target_tags = [
    "https-server"
  ]
}

resource "google_compute_firewall" "my_test_daichi_vpc_egress_main" {
  network        = google_compute_network.my_test_daichi_vpc.id
  name           = "my-test-daichi-vpc-egress-main"
  description    = ""
  direction      = "EGRESS"
  disabled       = false
  enable_logging = null
  priority       = 100
  source_ranges  = ["10.20.0.0/16"]
  allow {
    ports    = []
    protocol = "all"
  }
  target_tags = [
    "egress-all-allow"
  ]
}

resource "google_compute_route" "iowa_route_to_internal" {
  name              = "default-route-3ac289f9035d78b8"
  description       = "Default local route to the subnetwork 10.20.0.0/16."
  dest_range        = "0.0.0.0/0"
  network           = google_compute_network.my_test_daichi_vpc.self_link
  priority          = 0
  next_hop_instance = google_compute_instance.test_instance1.self_link
  depends_on = [
    google_compute_disk.test_instance1_disk,
    google_compute_instance.test_instance1,
    google_compute_network.my_test_daichi_vpc,
    google_compute_subnetwork.my_test_daichi_public_subnet_iowa
  ]
}

# resource "google_compute_route" "default_route_to_internal" {
#   name              = "default-route-f23375b2ab95593b"
#   description       = "Default local route to the subnetwork 10.12.0.0/16."
#   dest_range        = "10.12.0.0/16"
#   network           = google_compute_network.my_test_daichi_vpc.name
#   next_hop_instance = "next_hop_instance_zone"
#   priority          = 0
# }

# resource "google_compute_route" "default_route_to_external" {
#   name             = "default-route-97f0d5441ad976d3"
#   description      = "Default route to the Internet."
#   dest_range       = "0.0.0.0/0"
#   network          = google_compute_network.my_test_daichi_vpc.name
#   next_hop_gateway = "default-internet-gateway"
#   priority         = 1000
# }

resource "google_compute_instance" "test_instance1" {
  name                      = "instance-1"
  allow_stopping_for_update = null
  boot_disk {
    auto_delete       = true
    device_name       = "instance-1"
    kms_key_self_link = ""
    mode              = "READ_WRITE"
    source            = google_compute_disk.test_instance1_disk.name
  }
  can_ip_forward = false
  confidential_instance_config {
    enable_confidential_compute = false
  }
  deletion_protection = false
  description         = "スポットインスタンスとして起動"
  desired_status      = null
  enable_display      = false
  guest_accelerator   = []
  hostname            = ""
  machine_type        = "e2-micro"
  metadata = {
    ssh-keys = "root:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmn1x+rAND0XlG0mIAFZv53qx/E8087jPWDPgZPhEz7LFkEGszgIVQroSy8aKeeE3IfogFXfGfHd+EJr3zbbdDnut3PO3VhPkXy8Z5rTuAD7HKmiqAKuHaatQg3RISv+4AFmfvuIfg2SILuGWunAkVT/w0Sex4sQlPsXwjndIu5A9jTwLeAY10d7+JhF6X3dqGrXKXNlKDvo+nSp3uUzq2w60KIbGx12rmB8GGhD1oq4BTDMorAHVZQKlx6nnKKQIP19qPZcLCXEnSP6W/YKLdGrMvitXNlh5TZv80e8sWv25pgolanopxwiXpfokAu76KlvRu0zFR++wmyhDLBGZaAhI338UZEGV+rYOPJuq7eNtSqNrlKFJ+aGX3CM9UOF8AVMV2iPKHH9tqpv7rxHPt+tAXJeEoJ2Fk6WESmFWEMpB8+/I6RUiE6ft+2lfe+2/TdLJCSCBzTjR8riT1wPXSrn0gm1yD/w8Up4E/BEiR70DqqJgp/QGoKcKOagLk9dk= root@ubuntu2204.localdomain"
  }
  network_interface {
    access_config {
      # nat_ip                 = "35.208.27.187"
      network_tier           = "STANDARD"
      public_ptr_domain_name = ""
    }
    network    = google_compute_network.my_test_daichi_vpc.name
    subnetwork = google_compute_subnetwork.my_test_daichi_public_subnet_iowa.name
    network_ip = "10.20.0.2"
  }
  reservation_affinity {
    type = "ANY_RESERVATION"
  }
  scheduling {
    automatic_restart   = false
    min_node_cpus       = 0
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }
  service_account {
    email = "test-20220724-serviceaccount@angular-cosmos-280512.iam.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  tags = [
    "http-server",
    "https-server"
  ]
  zone = "us-central1-a"
}

resource "google_compute_disk" "test_instance1_disk" {
  name                      = "instance-1"
  description               = ""
  type                      = "pd-balanced"
  zone                      = "us-central1-a"
  image                     = "debian-11-bullseye-v20220719"
  physical_block_size_bytes = 4096
  provisioned_iops          = 0
  size                      = 10
  # users = [
  #   "https://www.googleapis.com/compute/v1/projects/angular-cosmos-280512/zones/us-central1-a/instances/instance-1"
  # ]
  labels = {
    environment = "dev"
  }
}
