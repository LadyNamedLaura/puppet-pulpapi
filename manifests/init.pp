class pulpapi(
  $yum_repos = {},
){

  create_resources('::pulpapi::yum_repo', $yum_repos);
}
