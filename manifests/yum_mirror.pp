# == Define: pulpapi::mirror
#
define pulpapi::yum_mirror (
  $upstream,
  $relative_url = $title,
) {
  $id = regsubst($title, '\W', '_', 'G')
  pulpapi::yum_repo{"mirror_${id}":
    relative_url     => "pub/${relative_url}",
    upstream         => $upstream,
    sync_schedule    => $::pulpapi::mirror_schedule,
    remove_missing   => true,
    retain_old_count => 0,
  }
}
