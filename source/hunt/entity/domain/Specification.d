﻿/*
 * Entity - Entity is an object-relational mapping tool for the D programming language. Referring to the design idea of JPA.
 *
 * Copyright (C) 2015-2018  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs.cn
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.entity.domain.Specification;

import hunt.entity;

interface Specification(T)
{
	Predicate toPredicate(Root!T root, CriteriaQuery!T criteriaQuery, CriteriaBuilder criteriaBuilder);
}
