include recipes-core/images/core-image-minimal.bb

IMAGE_FEATURES:append = " ssh-server-dropbear allow-root-login read-only-rootfs"
IMAGE_FEATURES:remove = " splash gnu-efi"
IMAGE_INSTALL:append = " packagegroup-ntpserver"

REPRODUCIBLE_TIMESTAMP_ROOTFS = "${@time.strftime('%s',time.gmtime())}"

inherit extrausers
EXTRA_USERS_PARAMS = "usermod -p '${ROOT_PASSWORD_HASH}' root;"
