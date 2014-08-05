module RDF
  class ORA < RDF::Vocabulary("http://vocab.ox.ac.uk/ora#")
    property :reviewStatus
    property :copyrightNote
    property :thesisDegreeLevel
    property :rightsHolderGroup
    property :embargoStatus
    property :embargoStart
    property :embargoEnd
    property :embargoReason
    property :embargoRelease
    property :affiliation
    property :author
    property :supervisor
    property :examiner
    property :hadCreationActivity
    property :hadPublicationActivity
    property :annotation
    property :oaReason
    property :oaStatus
    property :apcPaid
    property :refException
    property :isPartOfSeries
    property :dataStorageDetails
    property :DataStorageAgreement
    property :locator
    property :hasAgreement
    property :digitalSize
    property :digitalSizeAllocated
    property :digitalStorageSilo
    property :dataSteward
    property :dataContributor
    property :dataStorageInvoice
    property :monetaryValue
    property :monetaryStatus
    property :dateCollected
  end
end
