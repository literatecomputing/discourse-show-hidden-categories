import { apiInitializer } from "discourse/lib/api";
import Category from "discourse/models/category";
import Site from "discourse/models/site";

export default apiInitializer((api) => {
  api.modifyClass("route:discovery/categories", {
    pluginId: "show-hidden-categories",

    setupController(controller, model) {
      this._super(...arguments);

      const extras = settings.extra_categories;
      if (!extras?.length) {
        return;
      }

      const site = Site.current();

      const currentUser = api.getCurrentUser();

      extras.forEach((extra, idx) => {
        if (!extra.title) {
          return;
        }

        // Admins and group members can already see the real category
        if (currentUser?.admin) {
          return;
        }
        if (!currentUser) {
          return;
        }
        const groupName = Array.isArray(extra.group)
          ? extra.group[0]
          : extra.group;
        if (
          groupName &&
          currentUser?.groups?.some((g) => g.name === groupName)
        ) {
          return;
        }

        const id = -(10000 + idx);
        const color = (extra.color || "aaaaaa").replace(/^#/, "");

        // Skip if already registered (page revisit)
        if (site.categories.find((c) => c.id === id)) {
          if (!model.categories.find((c) => c.id === id)) {
            model.categories.pushObject(
              site.categories.find((c) => c.id === id)
            );
          }
          return;
        }

        const cat = Category.create({
          id,
          name: extra.title,
          color,
          text_color: "FFFFFF",
          icon: extra.icon || "lock",
          style_type: "icon",
          description_excerpt: extra.description || "",
          slug: `shc-${idx}`,
          topic_count: 0,
          post_count: 0,
          read_restricted: true,
          site,
        });

        // @tracked fields don't reliably initialize from create() args in
        // Ember Octane — set them explicitly after construction.
        cat.set("color", color);
        cat.set("icon", extra.icon || "lock");
        cat.set("read_restricted", true);

        // Register so Category.findById works (needed by topic tracking state)
        site.categories.push(cat);

        if (groupName) {
          Object.defineProperty(cat, "url", {
            get: () => `/g/${groupName}`,
            configurable: true,
          });
        }

        model.categories.pushObject(cat);
      });
    },
  });
});
