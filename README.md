# discourse-show-hidden-categories

**Show Hidden Categories**

Display categories that would otherwise be hidden from a user and offer a way for them to click to join the associated group. 

It's not actually showing the hidden category, but showing a placeholder that looks like a category

Clicking the fake/hidden category takes you to the groups page, where presumably the user can click to join or request to join.

When they return to the categories page they'll still see the fake category until they reload. I decided that this isn't so bad since it'll matter only the one time they join the group. 

Hidden categories are not shown to anonymous users since they can't join groups.
