resource "google_service_account" "service_account" {
  account_id   = "test-20220726-serviceaccount"
  description  = "for learning a gcp iam"
  display_name = "test_20220724_serviceaccount"
}

resource "google_project_iam_custom_role" "test_custom_roll" {
  role_id     = "1552"
  title       = "test-custom-roll"
  description = "作成日: 2022-07-24"
  stage       = "ALPHA"
  permissions = [
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.get",
    "compute.disks.list",
    "compute.firewalls.create",
    "compute.firewalls.delete",
    "compute.firewalls.get",
    "compute.firewalls.list",
    "compute.firewalls.update",
    "compute.images.create",
    "compute.images.delete",
    "compute.images.get",
    "compute.images.list",
    "compute.instances.attachDisk",
    "compute.instances.create",
    "compute.instances.createTagBinding",
    "compute.instances.delete",
    "compute.instances.deleteAccessConfig",
    "compute.instances.deleteTagBinding",
    "compute.instances.detachDisk",
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.osAdminLogin",
    "compute.instances.osLogin",
    "compute.instances.reset",
    "compute.instances.resume",
    "compute.networks.access",
    "compute.networks.create",
    "compute.networks.delete",
    "compute.networks.get",
    "compute.networks.list",
    "compute.networks.update",
    "compute.networks.updatePolicy",
    "compute.routes.create",
    "compute.routes.delete",
    "compute.routes.list",
    "compute.subnetworks.create",
    "compute.subnetworks.delete",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.subnetworks.update",
    "compute.zoneOperations.delete",
    "compute.zoneOperations.get",
    "compute.zoneOperations.getIamPolicy",
    "compute.zoneOperations.list",
    "compute.zoneOperations.setIamPolicy",
    "compute.zones.get",
    "compute.zones.list",
    "iam.serviceAccounts.getIamPolicy"
  ]
}

# Compute Engineを起動する際、必要最低限に加えて以下のロールをServiceAccountに割り当てなければ起動ができない
resource "google_project_iam_custom_role" "service_accounts_roll" {
  role_id     = "1894"
  title       = "サービス アカウント ユーザー"
  description = "作成日: 2022-07-25、ベース: サービス アカウント ユーザー"
  stage       = "ALPHA"
  permissions = [
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "resourcemanager.projects.get"
  ]
}

# IMPORTコマンド
# terraform import google_service_account_iam_policy.test_account_iam projects/angular-cosmos-280512/serviceAccounts/test-20220724-serviceaccount@angular-cosmos-280512.iam.gserviceaccount.com
resource "google_service_account_iam_policy" "test_account_iam" {
  service_account_id = google_service_account.service_account.name
  policy_data        = data.google_iam_policy.admin.policy_data
}

data "google_iam_policy" "admin" {
  binding {
    role = google_project_iam_custom_role.service_accounts_roll.title

    members = [
      google_service_account.service_account.id
    ]
  }
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      google_service_account.service_account.id
    ]
  }
  binding {
    role = "roles/iam.serviceAccountAdmin"

    members = [
      google_service_account.service_account.id
    ]
  }
}
