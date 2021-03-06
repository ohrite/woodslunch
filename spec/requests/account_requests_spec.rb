require 'spec_helper'

describe "Account requests" do

  describe 'new' do

    before(:each) do
      visit new_account_request_path
    end

    it 'displays form' do
      page.should have_xpath("//form[@action='/account_requests']")
    end

    it 'displayes required email'  do
      page.should have_xpath("//input[@id='account_request_email'][@required='required']")
    end

    it 'displays required first name' do
      page.should have_xpath("//input[@id='account_request_first_name'][@required='required']")
    end

    it 'displays required last name' do
      page.should have_xpath("//input[@id='account_request_last_name'][@required='required']")
    end

    it 'displays student first name' do
      pending 'JavaScript interaction test driver'
      # When I click 'Add a student'
      id = 'account_request_requested_students_attributes_0_first_name'
      page.should have_xpath("//input[@id='#{id}'][@required='required']")
    end

    it 'displays non-required student last name' do
      pending 'JavaScript interaction test driver'
      # When I click 'Add a student'
      id = 'account_request_requested_students_attributes_0_last_name'
      page.should have_xpath("//input[@id='#{id}'][@required='required']")
    end

    it 'displays non-required student grade' do
      pending 'JavaScript interaction test driver'
      # When I click 'Add a student'
      id = 'account_request_requested_students_attributes_0_grade'
      page.should have_xpath("//select[@id='#{id}'][contains(@class, 'required')]")
    end

    it 'allows for multiple students'
  end

  describe 'create' do

    let(:valid_params) {
      { 'account_request' => {
          'email'=>'john.doe@example.com',
          'first_name'=>'John',
          'last_name'=>'Doe',
          'requested_students_attributes' => {
            '0' => { 'first_name' => 'Bart',
                     'last_name' => 'Simpson',
                     'grade' => '4' } } } }
    }

    context 'given valid params' do
      it 'redirects to home page with flash message' do
        post_via_redirect account_requests_path, valid_params

        # NOTE: The rest of this is pending JavaScript test driver

        # Given I go to the new account request page
        # visit new_account_request_path

        # And I fill in 'Email' with 'marge.simpson@example.com'
        # fill_in 'Email', :with => 'marge.simpson@example.com'

        # And I fill in 'First name' with 'Marge'
        # fill_in 'account_request_first_name', :with => 'Marge'

        # And I fill in 'Last name' with 'Simpson'
        # fill_in 'account_request_last_name', :with => 'Simpson'

        # And I fill in 'Student first name' with 'Bart'
        # fill_in 'account_request_requested_students_attributes_0_first_name', :with => 'Bart'

        # And I fill in 'Student last name' with 'Simpson'
        # fill_in 'account_request_requested_students_attributes_0_last_name', :with => 'Simpson'

        # And I select '4' from 'Student grade'
        # select '4', :from => 'account_request_requested_students_attributes_0_grade'

        # And I click 'Submit Request'
        # click_button 'Submit Request'

        # Then I should be redirected to the home page
        # current_path.should == root_path

        # And I should see a flash message stating
        #     'Account request successfully submitted'
        # partial_flash = 'Account request successfully submitted'
        # page.should have_xpath(
        #     "//div[@class='flash'][@id='notice'][text()[contains(.,'#{partial_flash}')]]")
      end
    end

    context 'given no email parameter' do
      it 'displays error message' do
        post_via_redirect account_requests_path, valid_params['account_request'].except('email')
        assert_select '.error_notification'
      end
    end

    context 'given no first_name parameter' do
      it 'displays error message' do
        post_via_redirect account_requests_path, valid_params['account_request'].except('first_name')
        assert_select '.error_notification'
      end
    end

    context 'given no last_name parameter' do
      it 'displays error message' do
        post_via_redirect account_requests_path, valid_params['account_request'].except('last_name')
        assert_select '.error_notification'
      end
    end

    context 'given an email for an existing account' do
      it 'redirects to sign in page with flash message'
    end

  end

  describe 'index listing' do

    context 'given I am not logged in' do

      it 'redirects to the home page' do
        # When I go to the account requests index page
        visit account_requests_path

        # Then I should be redirected to the home page
        current_path.should == root_path
      end
    end

    context 'given I am logged in as a user' do

      before(:each) do
        user = Factory(:user)
        sign_in_as(user)
      end

      it 'redirects to the home page' do
        # When I go to the account requests index page
        visit account_requests_path

        # Then I should be redirected to the home page
        current_path.should == root_path
      end
    end

    context 'given I am logged in as an admin' do

      before(:each) do
        admin = Factory(:admin)
        sign_in_as(admin)
      end

      it 'permits access' do
        # When I go to the account requests index page
        visit account_requests_path

        # Then I should be redirected to the home page
        current_path.should == account_requests_path
      end

      context 'given an account request with two associated students' do

        let(:account_request) { Factory(:account_request) }
        let(:students) {
          [].tap do |a|
            a << Factory(:requested_student,
                :account_request => account_request)
          end
        }

        it 'displays user and student info' do
          # When I go to the account requests index page
          visit account_requests_path

          # Then I should see user info
          # And I should see students info
        end
      end
    end
  end

  describe 'approve' do

    before(:each) do
      # Given an account request
      @account_request = Factory(:account_request)
      # And I am logged in as an admin
      @admin = Factory(:admin)
      sign_in_as(@admin)
    end

    it 'sends email with activation token' do
      # When I go to the account requests listing
      visit account_requests_path

      # And I click on the "Approve" button
      within("div#pending div#account_request_#{@account_request.id}") do
        click_button 'Approve'
      end

      # Then I should be back on the account requests listing page
      current_path.should == account_requests_path

      # And I should see a flash notice 'Account activation has been sent'
      flash_notice = "An account activation email has been sent to " +
          "#{@account_request.email}"
      page.should have_css('div#notice', :text => flash_notice)

      # And I should see the account request listed under 'Approved'
      page.should have_css('div#approved span.user_info',
          :text => "#{@account_request.full_name}")
    end
  end

  describe 'deny' do

    before(:each) do
      # Given an account request
      @account_request = Factory(:account_request)
      # And I am logged in as an admin
      @admin = Factory(:admin)
      sign_in_as(@admin)
    end

    it 'destroys the record' do
      pending 'need to handle JavaScript confirmation dialog'
      # When I go to the account requests listing
      visit account_requests_path

      # And I click on the "Approve" button
      within("div#pending div#account_request_#{@account_request.id}") do
        click_link 'Deny'
      end

      # Then I should be back on the account requests listing page
      current_path.should == account_requests_path

      # And I should see a flash notice
      flash_notice = "Account request for #{@account_request.email} has been removed."
      page.should have_css('div#notice', :text => flash_notice)

      # And I should not see the account request listed
      page.should_not have_css("div#account_request_#{@account_request.id}")
    end
  end
end
