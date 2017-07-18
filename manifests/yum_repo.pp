# == Define: pulpapi::yum_repo
#
define pulpapi::yum_repo (
  $id                = $title,
  $ensure            = present,
  $relative_url      = $title,
  $upstream          = false,
  $sync_schedule     = undef,
  $repoview          = false,
  $remove_missing    = false,
  $retain_old_count  = undef,
  $allow_upload_from = [],
) {
  pulp_repo{$id :
    ensure => $ensure,
    notes  => {
      managed_by   => 'puppet',
      '_repo-type' => 'rpm-repo',
    },
  }

  if $ensure == present {
    $importer_config = {
      feed             => $upstream ? {
        false   => "${::pulpapi::httpurl}/.empty",
        default => regsubst($upstream,'^/',$::pulpapi::httpurl),
      },
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
      $override_config = $upstream ? {
        false   => {'force_full' => true},
        default => undef,
      }
      pulp_sync_schedule{$id :
        ensure          => present,
        sched           => $sync_schedule,
        override_config => $override_config,
        require         => Pulp_importer[$id],
      }
    }

    if ! empty($allow_upload_from) {
      $uploadperms = suffix($allow_upload_from, "::${id}")
      ::pulpapi::permission::repo_upload{$uploadperms:}
    }

    pulp_distributor{"${id}__yum_distributor":
      ensure       => present,
      id           => 'yum_distributor',
      type         => 'yum_distributor',
      repo         => $id,
      auto_publish => ($upstream and $sync_schedule),
      config       => {
        checksum_type   => 'sha256',
        http            => true,
        https           => false,
        relative_url    => $relative_url,
        generate_sqlite => true,
        #repoview => $repoview,
      },
      require      => Pulp_repo[$id],
    }
  }
}
