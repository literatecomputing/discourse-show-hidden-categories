# frozen_string_literal: true

RSpec.describe "Show Hidden Categories", type: :system do
  let(:group) { Fabricate(:group, name: "secret-group") }
  let(:admin) { Fabricate(:admin) }
  let(:regular_user) { Fabricate(:user) }
  let(:group_member) { Fabricate(:user).tap { |u| group.add(u) } }

  let(:theme) do
    upload_theme_or_component.tap do |t|
      t.update_setting(
        :extra_categories,
        [
          {
            title: "My Secret Category",
            description: "Join the group to see this.",
            color: "880022",
            icon: "lock",
            group: group.name,
          },
        ],
      )
    end
  end

  before { theme }

  shared_examples "hides the extra category" do
    it "does not show the hidden category" do
      visit "/categories"
      expect(page).not_to have_css("[data-category-id='-10000']")
    end
  end

  shared_examples "shows the extra category" do
    it "shows the hidden category teaser" do
      visit "/categories"
      expect(page).to have_css("[data-category-id='-10000']")
      expect(page).to have_text("My Secret Category")
    end

    it "links to the group page" do
      visit "/categories"
      expect(page).to have_css("[data-category-id='-10000'] a[href='/g/#{group.name}']")
    end
  end

  context "when not logged in" do
    include_examples "hides the extra category"
  end

  context "when logged in as a regular user not in the group" do
    before { sign_in(regular_user) }

    include_examples "shows the extra category"
  end

  context "when logged in as an admin" do
    before { sign_in(admin) }

    include_examples "hides the extra category"
  end

  context "when logged in as a member of the associated group" do
    before { sign_in(group_member) }

    include_examples "hides the extra category"
  end
end
