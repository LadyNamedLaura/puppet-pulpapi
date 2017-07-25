class { '::pulpapi':
  purge_repos => true,
  mirrors     => {
    'centos-7-x86_64' => 'http://mirror.centos.org/centos/7/x86_64',
  },
}
