class pulpapi(
  $purge_repos     = false, # set this to true in hiera, we don't want to nuke pulp if we lose hiera
  $yum_repos       = {},
  $mirrors         = {}, # { relpath => source }
  $mirror_schedule = "P1DT", # daily
){

  resources {[
    'pulp_repo',
    'pulp_distributor',
    'pulp_importer',
    'pulp_sync_schedule',
    ]:
    purge => $purge_repos,
  }

  create_resources('::pulpapi::yum_repo', $yum_repos);

  $mirror_relpaths = keys($mirrors)
  pulpapi::yum_mirror_wrapper{$mirror_relpaths:
    mirrorhash => $mirrors,
  }
}
