import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance, updateCurrentUser } from "discourse/tests/helpers/acceptance-test";

const FAKE_CATEGORY_ID = -10000;
const TEST_GROUP = "secret-group";

acceptance("Show Hidden Categories | visibility", function (needs) {
  needs.pretender((server, helper) => {
    server.get("/categories.json", () =>
      helper.response({
        category_list: {
          categories: [],
          featured_topics: [],
        },
      })
    );
  });

  test("extra category appears for a regular user not in the group", async function (assert) {
    await visit("/categories");
    assert
      .dom(`[data-category-id='${FAKE_CATEGORY_ID}']`)
      .exists("fake category row is rendered for a regular user");
  });

  test("extra category is hidden for admins", async function (assert) {
    updateCurrentUser({ admin: true });
    await visit("/categories");
    assert
      .dom(`[data-category-id='${FAKE_CATEGORY_ID}']`)
      .doesNotExist("fake category row is not rendered for admins");
  });

  test("extra category is hidden for members of the associated group", async function (assert) {
    updateCurrentUser({
      admin: false,
      groups: [{ id: 42, name: TEST_GROUP }],
    });
    await visit("/categories");
    assert
      .dom(`[data-category-id='${FAKE_CATEGORY_ID}']`)
      .doesNotExist(
        "fake category row is not rendered for users already in the group"
      );
  });

  test("extra category links to the group page", async function (assert) {
    await visit("/categories");
    assert
      .dom(`[data-category-id='${FAKE_CATEGORY_ID}'] a.category-title-link`)
      .hasAttribute(
        "href",
        `/g/${TEST_GROUP}`,
        "category title links to the group join page"
      );
  });
});
