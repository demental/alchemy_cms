require 'spec_helper'

module Alchemy
  describe Admin::PagesController do

    before(:each) do
      activate_authlogic
      UserSession.create FactoryGirl.create(:admin_user)
    end

    describe "#flush" do

      it "should remove the cache of all pages" do
        post :flush, {:format => :js}
        response.status.should == 200
      end

    end

    describe '#new' do

      context "pages in clipboard" do

        let(:clipboard) { session[:clipboard] = Clipboard.new }
        let(:page) { mock_model('Page', {:id => 10, :name => 'Foobar', :parent_id => 1}) }

        before(:each) do
          clipboard[:pages] = [{:id => page.id, :action => 'copy'}]
        end

        it "should load all pages from clipboard" do
          get :new, {:page_id => page.id, :format => :js}
          assigns(:clipboard_items).should be_kind_of(Array)
        end

      end

    end

    describe '#create' do

      render_views

      context "with paste_from_clipboard in parameters" do

        let(:clipboard) { session[:clipboard] = Clipboard.new }
        let(:page_in_clipboard) { @page ||= FactoryGirl.create(:public_page) }
        let(:parent) { @page ||= FactoryGirl.create(:public_page) }

        before(:each) do
          clipboard[:pages] = [{:id => page_in_clipboard.id, :action => 'cut'}]
        end

        it "should create a page from clipboard" do
          post :create, {:paste_from_clipboard => page_in_clipboard.id, :page => {:parent_id => parent.id}, :format => :js}
          response.status.should == 200
          response.body.should match /window.location.*admin.*pages/
        end

      end

    end

    describe '#copy_language_tree' do

      before(:each) do
        @language = Language.get_default
        @language_root = FactoryGirl.create(:language_root_page, :language => @language, :name => 'Intro')
        @level_1 = FactoryGirl.create(:public_page, :language => @language, :parent_id => @language_root.id, :visible => true, :name => 'Level 1')
        @level_2 = FactoryGirl.create(:public_page, :language => @language, :parent_id => @level_1.id, :visible => true, :name => 'Level 2')
        @level_3 = FactoryGirl.create(:public_page, :language => @language, :parent_id => @level_2.id, :visible => true, :name => 'Level 3')
        @level_4 = FactoryGirl.create(:public_page, :language => @language, :parent_id => @level_3.id, :visible => true, :name => 'Level 4')
        @new_language = FactoryGirl.create(:language)
        session[:language_code] = @new_language.code
        session[:language_id] = @new_language.id
        post :copy_language_tree, {:languages => {:new_lang_id => @new_language.id, :old_lang_id => @language.id}}
        @new_lang_root = Page.language_root_for(@new_language.id)
      end

      it "should copy all pages" do
        @new_lang_root.should_not be_nil
        @new_lang_root.descendants.count.should == 4
        @new_lang_root.descendants.collect(&:name).should == ["Level 1 (Copy)", "Level 2 (Copy)", "Level 3 (Copy)", "Level 4 (Copy)"]
      end

      it "should not set layoutpage attribute to nil" do
        @new_lang_root.layoutpage.should_not be_nil
      end

      it "should not set layoutpage attribute to true" do
        @new_lang_root.layoutpage.should_not be_true
      end

    end

  end
end
