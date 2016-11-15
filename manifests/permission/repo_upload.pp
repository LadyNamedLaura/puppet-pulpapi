# == Define: pulpapi::permission::repo_upload
#
define pulpapi::permission::repo_upload (
  $user = undef,
  $repoid = undef,
) {
  if $user == undef or $repoid == undef {
    if $user or $repoid {
      fail('either set both user and repoid, or let me get both from the title')
    }
    $tmp = split($title,'::')
    $_user = $tmp[0]
    $_repoid = $tmp[1]
  } else {
    $_user = $user
    $_repoid = $repoid
  }
  pulp_permission{"${_user}::upload_${_repoid}":
    user => $_user,
    path => "/v2/repositories/${_repoid}/",
    operations => ['READ','UPDATE','CREATE','EXECUTE'],
    require => Pulp_user[$_user],
  }
  ensure_resource('pulpapi::permission::upload',$_user)
}
