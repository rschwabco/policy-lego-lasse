package lego.api.__cno.__properties

import data.customer_hierarchy
import data.property_groups

import future.keywords.in
import future.keywords.every

User := input.user
Links := input.user.attributes.properties.Links
Properties := get_input_properties()

default allow = false
allow {
  #Check that a link grants the required access:
  some i
  Link := Links[i]

  # Check that the user is allowed to access this part of the hierarchy:
	has_access_to_customer(Link, input.resource.cno)

  # Check that the user has access to all the properties:

  every Property in Properties {
    GroupID := Link.Groups[_]
    Group := property_groups[GroupID]
    Group.Properties[_] == Property
  }
}

get_input_properties() = input.resource.properties {
  input.resource.properties
} else = [] {
  true
}

has_access_to_customer(Link, cno) = true {
  Customer := Link.Customers[_]
  is_parent(Customer, cno, customer_hierarchy)
} else = false {
  true
}

is_parent(ParentID, childID, hierarchy) = true {
  ParentID == childID
} else = true {
  child := hierarchy[childID]
  is_Parent_obj(ParentID, child, hierarchy)
} else = false {
  true
}

# Search through levels without using recursion:
is_Parent_obj(ParentID, child, hierarchy) = true {
  ParentID == child.Parent
} else = true {
  P2 := hierarchy[child.Parent]
  ParentID == P2.Parent
} else = true {
  P2 := hierarchy[child.Parent]
  P3 := hierarchy[P2.Parent]
  ParentID == P3.Parent
} else = true {
  P2 := hierarchy[child.Parent]
  P3 := hierarchy[P2.Parent]
  P4 := hierarchy[P3.Parent]
  ParentID == P4.Parent
} else = true {
  P2 := hierarchy[child.Parent]
  P3 := hierarchy[P2.Parent]
  P4 := hierarchy[P3.Parent]
  P5 := hierarchy[P4.Parent]
  ParentID == P5.Parent
} else = true {
  P2 := hierarchy[child.Parent]
  P3 := hierarchy[P2.Parent]
  P4 := hierarchy[P3.Parent]
  P5 := hierarchy[P4.Parent]
  P6 := hierarchy[P5.Parent]
  ParentID == P6.Parent
} else = false {
  true
}