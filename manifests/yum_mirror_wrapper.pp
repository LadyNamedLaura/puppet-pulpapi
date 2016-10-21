# == Define: pulpapi::mirror
#
define pulpapi::yum_mirror_wrapper (
  $mirrorhash,
) {
  pulpapi::yum_mirror{ $title:
    upstream => $mirrorhash[$title],
  }
}
