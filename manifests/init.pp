class pulpapi(
  $apiuser           = 'admin',
  $apipass           = 'admin',
  $httpurl           = "http://${::fqdn}/pulp/repos/",
  $apiurl            = "https://${::fqdn}/pulp/api/v2/",
  $purge_repos       = false, # set this to true in hiera, we don't want to nuke pulp if we lose hiera
  $purge_permissions = true,
  $yum_repos         = {},
  $mirrors           = {}, # { relpath => source }
  $mirror_schedule   = 'P1DT', # daily
  $users             = {},
){

  file {$::pulp_apiconfig_path:
    ensure  => file,
    content => template('pulpapi/pulpapi.conf.erb'),
  }

  resources {[
      'pulp_repo',
      'pulp_distributor',
      'pulp_importer',
      'pulp_sync_schedule',
    ]:
      purge => $purge_repos,
  }
  resources {[
      'pulp_user',
      'pulp_permission',
    ]:
      purge => $purge_permissions,
  }

  create_resources('::pulpapi::yum_repo', $yum_repos)

  ::profile_pulp::yum_repo{'__empty__':
    ensure       => present,
    relative_url => '.empty',
  }

  $mirror_relpaths = keys($mirrors)
  pulpapi::yum_mirror_wrapper{$mirror_relpaths:
    mirrorhash => $mirrors,
  }
  create_resources('pulp_user', $users)
}
