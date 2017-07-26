class pulpapi(
  $apiuser           = 'admin',
  $apipass           = 'admin',
  $httpurl           = "http://${::fqdn}/pulp/repos/",
  $apiurl            = "https://${::fqdn}/pulp/api/v2/",
  $purge_repos       = false, # default to false to prevent accidental nuking without hiera
  $purge_permissions = true,
  $yum_repos         = {},
  $mirrors           = {}, # { relpath => source }
  $mirror_schedule   = 'P1DT', # daily
  $users             = {},
){

  file { "${::puppet_vardir}/pulpapi.json":
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

  # this is a special always empty repo
  # it exists to allow repositories without an upstream to use retain_old_count
  # in order to only keep X number of versions.
  ::pulpapi::yum_repo{'__empty__':
    ensure       => present,
    relative_url => '.empty',
  }

  $mirror_relpaths = keys($mirrors)
  pulpapi::yum_mirror_wrapper{$mirror_relpaths:
    mirrorhash => $mirrors,
  }
  create_resources('pulp_user', $users)
}
