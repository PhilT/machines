require 'spec_helper'

describe 'packages/gmate' do
  before(:each) do
    load_package('gmate')
    AppConf.appsroot = 'apps_root'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   gmate - Clone gmate for gEdit from Github and set some preferences and plugins",
      "RUN    git clone -q git@github.com:PhilT/gmate.git workspace/gmate",
      "SUDO   cd workspace/gmate && ./install.sh",
      'RUN    gconftool-2 --set "/apps/gedit-2/plugins/active-plugins" --type list --list-type=string ["text_tools","smart_indent","align","rails_hotkeys","trailsave","gemini","rubyonrailsloader","gedit_openfiles","quickhighlightmode","completion","time","docinfo","filebrowser","snippets","spell","indent","tabswitch"]',
      'RUN    gconftool-2 --set "/apps/gedit-2/plugins/smart_indent/haml_tab_size" --type int 2',
      'RUN    gconftool-2 --set "/apps/gedit-2/plugins/smart_indent/js_tab_size" --type int 2',
      'RUN    gconftool-2 --set "/apps/gedit-2/plugins/smart_indent/markdown_tab_size" --type int 2',
      'RUN    gconftool-2 --set "/apps/gedit-2/plugins/smart_indent/plain_text_tab_size" --type int 2',
      'RUN    gconftool-2 --set "/apps/gedit-2/plugins/smart_indent/sass_tab_size" --type int 2',
      'RUN    gconftool-2 --set "/apps/gedit-2/plugins/smart_indent/yaml_tab_size" --type int 2',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/bracket_matching/bracket_matching" --type bool true',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/current_line/highlight_current_line" --type bool true',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/cursor_position/restore_cursor_position" --type bool true',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/line_numbers/display_line_numbers" --type bool true',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/right_margin/display_right_margin" --type bool true',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/right_margin/right_margin_position" --type int 120',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/colors/scheme" --type string "railscasts"',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/tabs/insert_spaces" --type bool true',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/tabs/tabs_size" --type int 2',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/wrap_mode/wrap_mode" --type string "GTK_WRAP_NONE"',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/editor/save/create_backup_copy" --type bool false',
      'RUN    gconftool-2 --set "/apps/gedit-2/preferences/ui/toolbar/toolbar_visible" --type bool false'
    ]
  end
end

