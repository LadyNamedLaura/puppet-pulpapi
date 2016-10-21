class pulpapi(
  $yum_repos       = {},
  $mirrors         = {}, # { relpath => source }
  $mirror_schedule = "P1DT", # daily
){

  create_resources('::pulpapi::yum_repo', $yum_repos);

  $mirror_relpaths = keys($mirrors)
  pulpapi::yum_mirror_wrapper{$mirror_relpaths:
    mirrorhash => $mirrors,
  }
}
