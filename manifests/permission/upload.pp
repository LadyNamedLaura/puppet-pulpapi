# == Define: pulpapi::permission::upload
#
define pulpapi::permission::upload (
  $user = $title,
) {
  pulp_permission{"${user}::upload":
    user       => $user,
    path       => '/v2/content/uploads/',
    operations => ['READ','UPDATE','CREATE','DELETE'],
    require    => Pulp_user[$user],
  }
  pulp_permission{"${user}::task":
    user       => $user,
    path       => '/v2/tasks/',
    operations => ['READ',],
    require    => Pulp_user[$user],
  }
}
