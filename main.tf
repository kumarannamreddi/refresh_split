# 1. Find the tags resulted ec2
data "aws_instances" "customer_instances" {
  filter {
    name   = "tag:unique_id"
    values = "${split(",", var.input_tags)}"
  }
}


resource "null_resource" "customer_resource_exec" {

    for_each = toset("${data.aws_instances.customer_instances.private_ips}")

    # Execute invoke.sh
    provisioner "remote-exec" {
        inline = [
           "echo 'Starting refreshing'",
           "sudo su - oracle /bin/csh -c 'db XPPNP && spdba</home/oracle/shutdown.sql'",
           "sudo umount -d /u01/data"
        ]

        connection {
            type     = "ssh"
            user     = "ec2-user"
            private_key = "${file(var.pem_file)}"
            host     = "${each.key}"
        }
    }
}

# Identify latest snapshot
data "aws_ebs_snapshot" "db_snap" {
  most_recent = true
  owners      = ["${var.tag_owners}"]

  filter {
    name   = "tag:Name"
    values = ["${var.oraclesid}*"]
  }
}
/*
data "aws_ebs_volume" "assigned_volumes" {
count = length("${data.aws_instances.customer_instances.private_ips}")

most_recent = true
filter {
name = "tag:instance_id"
values = ["${data.aws_instances.customer_instances.ids[count.index]}"]
}

}
*/

resource "aws_ebs_volume" "db_snapshot-datafiles" {

        count = length("${data.aws_instances.customer_instances.private_ips}")
#for_each = toset("${data.aws_instances.customer_instances.private_ips}")
        availability_zone = "us-east-1a"
        size = "${var.tag_size}"
        type = "${var.tag_type}"
        snapshot_id = "${data.aws_ebs_snapshot.db_snap.id}"
        tags =  {
                description = "ebs volume for the db_snapshot DB datafiles for migration"
                Name = "db_snapshot-datafiles"
                snapshot = "${data.aws_ebs_snapshot.db_snap.id}"
                instance_id = "${data.aws_instances.customer_instances.ids[count.index]}"
        }
}
/*
data "aws_ebs_volume" "assigned_volumes" {
count = length("${data.aws_instances.customer_instances.private_ips}")

most_recent = true
filter {
name = "tag:instance_id"
values = ["${data.aws_instances.customer_instances.ids[count.index]}"]
}

}
*/
output "myvolumes" {
 value = "${aws_ebs_volume.db_snapshot-datafiles[0].id}"
}

output "myvolume1" {
 value = "${aws_ebs_volume.db_snapshot-datafiles[0].id}"
}

/*
resource "aws_volume_attachment" "ebs_volume_detachment" {

        count =  length("${data.aws_instances.customer_instances.private_ips}")

        device_name = "/dev/xvdb"
        volume_id = "${data.aws_ebs_volume.assigned_volumes[count.index]["volume_id"]}"
        instance_id = "${data.aws_instances.customer_instances.ids[count.index]}"
        force_detach = true
}
*/

resource "random_string" "randomdevice" {
  length = 1
number = false
special = false
upper = false
}

resource "aws_volume_attachment" "db_snapshot-datafiles-attachment" {
       
        count =  length("${data.aws_instances.customer_instances.private_ips}")      

        device_name = "/dev/xvd${random_string.randomdevice.result}"
        volume_id = "${aws_ebs_volume.db_snapshot-datafiles[count.index].id}"
        instance_id = "${data.aws_instances.customer_instances.ids[count.index]}"
}

resource "null_resource" "mount_and_start" {

    for_each = toset("${data.aws_instances.customer_instances.private_ips}")

    # Execute invoke.sh
    provisioner "remote-exec" {
        inline = [
           "echo 'Mounting and starting service....'",
           "sudo mount /dev/nvme2n1  /u01/data",
           "sudo su - oracle /bin/csh -c 'db XPPNP && spdba</home/oracle/startupcode.sql'",
        ]

        connection {
            type     = "ssh"
            user     = "ec2-user"
            private_key = "${file(var.pem_file)}"
            host     = "${each.key}"
        }
    }
}

