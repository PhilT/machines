require 'spec_helper'

describe 'packages/gnome' do
  before(:each) do
    load_package('gnome')
    AppConf.log = mock 'Logger', :puts => nil
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      'RUN    gconftool-2 --set "/apps/metacity/general/titlebar_font" --type string "Arial Bold 10"',
      'RUN    gconftool-2 --set "/apps/metacity/general/num_workspaces" --type int 1',
      'RUN    gconftool-2 --set "/apps/nautilus/preferences/desktop_font" --type string "Sans 9"',
      'RUN    gconftool-2 --set "/apps/nautilus/preferences/default_folder_viewer" --type string "compact_view"',
      'RUN    gconftool-2 --set "/desktop/gnome/interface/font_name" --type string "Sans 9"',
      'RUN    gconftool-2 --set "/desktop/gnome/interface/document_font_name" --type string "Sans 9"',
      'RUN    gconftool-2 --set "/desktop/gnome/interface/monospace_font_name" --type string "Monospace 9"'
    ]
  end
end

