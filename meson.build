project('com.github.kjlaw89.webwatcher', ['vala', 'c'],
    version : '1.0.0',
    license: 'GPL-3.0'
)

gnome = import('gnome')
i18n = import('i18n')

gresource = gnome.compile_resources(
    'as-resources', 'data/com.github.kjlaw89.webwatcher.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h'
]

subdir('data')
subdir('po')
subdir('src')

dependencies = [
    dependency('granite'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('glib-2.0'),
    dependency('sqlite3'),
    dependency('libsoup-2.4'),
    dependency('json-glib-1.0'),
    dependency('unity'),
    dependency('appindicator3-0.1')
]

executable('com.github.kjlaw89.webwatcher',
    sources,
    gresource,
    c_args: c_args,
    dependencies: dependencies,
    install : true
)

declare_dependency(
    dependencies: dependencies
)

meson.add_install_script('post_install.py')
