package lego.api.__cno.__properties

import data.customer_hierarchy
import data.property_groups

import future.keywords.in
import future.keywords.every

User := input.user
Links := input.user.attributes.properties.Links

default allow = false
allow {

  #Check that there is a link, which grants access to the customer and properties from input:
  some i
  Link := Links[i]

  link_grants_access_to_customer(Link, input.resource.cno)

  check_valid_time(Link)

  # Check that the user has access to all the properties:
  every Property in get_input_properties() {
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

check_valid_time(Link) = true {
  now := time.now_ns()
  check_valid_from(Link, now)
  check_valid_to(Link, now)
} else = false {
  true
}

check_valid_from(Link, now) = time.parse_rfc3339_ns(from) <= now {
  from := Link.ValidFrom
} else = true {
  # No valid from specified, so assume OK:
  true
}

check_valid_to(Link, now) = now <= time.parse_rfc3339_ns(to) {
  to := Link.ValidTo
} else = true {
  # No valid to specified, so assume OK:
  true
}

link_grants_access_to_customer(Link, cno) = true {
  # If a link is a direct match, then OK:
  Link.Customers[_] == cno
} else = true {
  # Otherwise, if a customer in Link is an ancestor to cno, then also OK:
  customer_hierarchy[cno].Ancestors[_] == Link.Customers[_]
} else = false {
  true
}
