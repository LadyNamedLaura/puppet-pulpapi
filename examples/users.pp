class { '::pulpapi':
  users => {
    'john' => {password => 'secret'},
  },
}
