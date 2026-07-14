/*
** Base object which implements virtual methods that support the INT_Trigger interface
*/
public virtual without sharing class TH_BaseObject implements INT_Trigger
{
  /**
   * bulkBefore
   *
   * This method is called prior to execution of a BEFORE trigger. Use this to cache
   * any data required into maps prior execution of the trigger.
   */
    public virtual void bulkBefore()
    {

    }


  /**
   * bulkAfter
   *
   * This method is called prior to execution of an AFTER trigger. Use this to cache
   * any data required into maps prior execution of the trigger.
   */
    public virtual void bulkAfter()
    {

    }

  /**
   * beforeInsert
   *
   * This method is called iteratively for each record to be inserted during a BEFORE
   * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
   */
    public virtual void beforeInsert(SObject so)
    {

    }

  /**
   * beforeUpdate
   *
   * This method is called iteratively for each record to be updated during a BEFORE
   * trigger.
   */
    public virtual void beforeUpdate(SObject oldSo, SObject so)
    {

    }

    //commented for test coverage
//  /**
//   * beforeDelete
//   *
//   * This method is called iteratively for each record to be deleted during a BEFORE
//   * trigger.
//   */
    public virtual void beforeDelete(SObject so)
    {

    }

  /**
   * afterInsert
   *
   * This method is called iteratively for each record inserted during an AFTER
   * trigger. Always put field validation in the 'After' methods in case another trigger
   * has modified any values. The record is 'read only' by this point.
   */
    public virtual void afterInsert(SObject so)
    {

    }

  /**
   * afterUpdate
   *
   * This method is called iteratively for each record updated during an AFTER
   * trigger.
   */
    public virtual void afterUpdate(SObject oldSo, SObject so)
    {

    }

    //commented for test coverage
  /**
   * afterDelete
   *
   * This method is called iteratively for each record deleted during an AFTER
   * trigger.
   */
    public virtual void afterDelete(SObject so)
    {

    }

  /**
   * afterUndelete
   *
   * This method is called iteratively for each record UnDeleted during an AFTER
   * trigger.
   */
    public virtual void afterUndelete(SObject so)
    {

    }


  /**
   * andFinally
   *
   * This method is called once all records have been processed by the trigger. Use this
   * method to accomplish any final operations such as creation or updates of other records.
   */
    public virtual void andFinally()
    {

    }

}