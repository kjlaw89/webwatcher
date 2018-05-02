project('com.github.kjlaw89.web-watcher', ['vala', 'c'],
    version : '0.0.1',
    license: 'GPL-3.0'
)

gnome = import('gnome')
i18n = import('i18n')

gresource = gnome.compile_resources(
    'as-resources', 'data/com.github.kjlaw89.web-watcher.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h',
  '-DGWEATHER_I_KNOW_THIS_IS_UNSTABLE'
]

subdir('data')
subdir('po')
subdir('src')

executable('com.github.kjlaw89.web-watcher',
    sources,
    gresource,
    c_args: c_args,
    dependencies :[
        dependency('granite'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('glib-2.0'),
        dependency('sqlite3'),
        dependency('libsoup-2.4'),
        dependency('json-glib-1.0'),
        dependency('unity'),
        dependency('appindicator3-0.1')
    ],
    install : true
)

meson.add_install_script('post_install.py')
