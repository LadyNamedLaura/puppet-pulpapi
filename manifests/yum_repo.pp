# == Define: pulpapi::yum_repo
#
define pulpapi::yum_repo (
  $id               = $title,
  $relative_url     = "$title",
  $upstream         = undef,
  $sync_schedule    = undef,
  $repoview         = false,
  $remove_missing   = false,
  $retain_old_count = undef,
) {
  pulp_repo{$id :
    ensure => 'present',
    notes  => {
      managed_by => 'puppet',
    }
  }
  if $upstream {
    $importer_config = {
      feed             => regsubst($upstream,'^/',$::pulpapi::httpurl),
      retain_old_count => $retain_old_count,
      remove_missing   => $remove_missing,
    }

    pulp_importer{$id :
      ensure  => present,
      type    => 'yum_importer',
      config  => delete_undef_values($importer_config),
      require => Pulp_repo[$id],
    }

    if $sync_schedule {
      pulp_sync_schedule{$id :
        ensure  => present,
        sched   => $sync_schedule,
        require => Pulp_importer[$id],
      }
    }
  }

  pulp_distributor{"${id}__yum_distributor":
    ensure       => present,
    id           => 'yum_distributor',
    type         => 'yum_distributor',
    repo         => $id,
    auto_publish => ($upstream and $sync_schedule),
    config       => {
      checksum_type   => "sha256",
      http            => true,
      https           => false,
      relative_url    => $relative_url,
      generate_sqlite => true,
#      repoview => $repoview,
    },
    require      => Pulp_repo[$id],
  }
}
