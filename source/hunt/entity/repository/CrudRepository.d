/*
 * Entity - Entity is an object-relational mapping tool for the D programming language. Referring to the design idea of JPA.
 *
 * Copyright (C) 2015-2018  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs.cn
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
module hunt.entity.repository.CrudRepository;

import hunt.entity.Persistence;
import hunt.entity.DefaultEntityManagerFactory;
import hunt.entity;

public import hunt.entity.repository.Repository;

class CrudRepository(T, ID) : Repository!(T, ID)
{
    protected EntityManager _manager;

    this(EntityManager manager = null) {
        _manager = manager;
    }

    public EntityManager getEntityManager() {
        return _manager;
    }

    public EntityManager createEntityManager()
    {
        return defaultEntityManagerFactory().createEntityManager();
    }

    public long count()
    {
        auto em = _manager ? _manager : createEntityManager();
        scope(exit) {if (!_manager) em.close();}

        CriteriaBuilder builder = em.getCriteriaBuilder();
        auto criteriaQuery = builder.createQuery!T;
        Root!T root = criteriaQuery.from();
        criteriaQuery.select(builder.count(root));
        
        Long result = cast(Long)(em.createQuery(criteriaQuery).getSingleResult());
        
        return result.longValue();
    }

    public void remove(T entity)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        em.remove!T(entity);
    }

    public void removeAll()
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        foreach (entity; findAll())
        {
            em.remove!T(entity);
        }
    }
    
    public void removeAll(T[] entities)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        foreach (entity; entities)
        {
            em.remove!T(entity);
        }
    }

    public void removeById(ID id)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        em.remove!T(id);
        
    }
    
    public bool existsById(ID id)
    {
        T entity = this.findById(id);
        return (entity !is null);
    }

    public T[] findAll()
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        CriteriaBuilder builder = em.getCriteriaBuilder();
        auto criteriaQuery = builder.createQuery!(T);
        Root!T root = criteriaQuery.from();
        TypedQuery!T typedQuery = em.createQuery(criteriaQuery.select(root));
        return typedQuery.getResultList();
    }

    public T[] findAllById(ID[] ids)
    {
        T[] entities;
        foreach (id; ids)
        {
            T entity = this.findById(id);
            if (entity !is null)
                entities ~= entity;
        }
        return entities;
    }

    public T findById(ID id)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        T result = em.find!T(id);
        return result;
    }

    public T save(T entity)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        if (mixin(GenerateFindById!T()) is null)
        {
            em.persist(entity);
        }
        else
        {
            em.merge!T(entity);
        }
        return entity;
    }

    public T[] saveAll(T[] entities)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        T[] resultList;
        foreach (entity; entities)
        {
            if (mixin(GenerateFindById!T()) is null)
            {
                resultList ~= em.persist(entity);
            }
            else
            {
                em.merge!T(entity);
                resultList ~= entity;
            }
        }
        return resultList;
    }

    public T insert(T entity)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        em.persist(entity);
        return entity;
    }
    public T[] insertAll(T[] entities)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        T[] resultList;
        foreach (entity; entities)
        {
            resultList ~= em.persist(entity);
        }
        return resultList;
    }

    public T update(T entity)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        em.merge!T(entity);
        return entity;
    }
    public T[] updateAll(T[] entities)
    {
        auto em = _manager ? _manager : defaultEntityManagerFactory().createEntityManager();
        scope(exit) {if (!_manager) em.close();}
        T[] resultList;
        foreach (entity; entities)
        {
            em.merge!T(entity);
            resultList ~= entity;
        }
        return resultList;
    }

}

string GenerateFindById(T)()
{
    return "em.find!T(entity." ~ getSymbolsByUDA!(T, PrimaryKey)[0].stringof ~ ")";
}
