/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "null" {
  version = "~> 1.0"
}

module "automatic_labelling" {
  source = "../../../examples/automatic_labelling"

  project_id = "${var.project_id}"
  region     = "${var.region}"
}

resource "null_resource" "wait_for_cloud_functions_function" {
  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = ["module.automatic_labelling"]
}

resource "google_compute_instance" "main" {
  boot_disk = {
    initialize_params = {
      image = "debian-cloud/debian-9"
    }
  }

  machine_type = "f1-micro"
  name         = "unlabelled"
  zone         = "${var.zone}"

  network_interface = {
    network = "default"
  }

  project = "${var.project_id}"

  depends_on = ["null_resource.wait_for_cloud_functions_function"]
}
