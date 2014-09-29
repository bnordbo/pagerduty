{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

-- Module      : Network.PagerDuty.Services
-- Copyright   : (c) 2013-2014 Brendan Hay <brendan.g.hay@gmail.com>
-- License     : This Source Code Form is subject to the terms of
--               the Mozilla Public License, v. 2.0.
--               A copy of the MPL can be found in the LICENSE file or
--               you can obtain it at http://mozilla.org/MPL/2.0/.
-- Maintainer  : Brendan Hay <brendan.g.hay@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)

-- | This API lets you access and manipulate the services across your account.
--
-- A service is an endpoint (like Nagios, email, or an API call) that
-- generates events, which Pagerduty normalizes and dedupes, creating incidents.
--
-- When a service is shown inlined in other resources, a deleted service will
-- have its @html_url@ attribute set to 'Nothing'.
--
-- See: <http://developer.pagerduty.com/documentation/rest/services>
module Network.PagerDuty.Services
    (
    -- * List Services
      listServices
    , lsTimeZone

    -- * Create Service
    , createService
    , csName
    , csEscalationPolicyId
    , csType
    , csVendorId
    , csDescription
    , csAcknowledgementTimeout
    , csAutoResolveTimeout
    , csSeverityFilter

    -- * Get Service
    , getService

    -- * Update Service
    , updateService

    -- * Delete Service
    , deleteService

    -- * Enable Service
    , enableService

    -- * Disable Service
    , disableService

    -- * Regenerate Key
    , regenerateKey

    -- * Types
    , EmailFilterMode       (..)
    , EmailIncidentCreation (..)
    , MatchMode             (..)
    , ServiceStatus         (..)
    , ServiceType           (..)
    , SeverityFilter        (..)

    , IncidentCounts
    , cntTriggered
    , cntAcknowledged
    , cntResolved
    , cntTotal

    , EmailFilters          (..)
    , efsId
    , efsSubjectMode
    , efsSubjectRegex
    , efsBodyMode
    , efsBodyRegex
    , efsFromEmailMode
    , efsFromEmailRegex

    , PolicyInfo
    , pinfoId
    , pinfoName

    , Service
    , svcId
    , svcName
    , svcDescription
    , svcServiceUrl
    , svcServiceKey
    , svcAutoResolveTimeout
    , svcAcknowledgementTimeout
    , svcCreatedAt
    , svcStatus
    , svcLastIncidentTimestamp
    , svcEmailIncidentCreation
    , svcIncidentCounts
    , svcEmailFilterMode
    , svcType
    , svcEscalationPolicy
    , svcEmailFilters
    , svcSeverityFilter
    ) where

import           Control.Lens
import           Data.Aeson
import           Data.Aeson.Lens
import qualified Data.ByteString.Char8            as BS
import           Data.ByteString.Conversion
import           Data.Monoid
import           Data.Text                        (Text)
import           Network.HTTP.Types
import           Network.PagerDuty.Services.Types
import           Network.PagerDuty.JSON
import           Network.PagerDuty.Types

services xs = path .~ "services" : xs

includes :: Query
includes =
    [ ("include[]", Just "escalation_policy")
    , ("include[]", Just "email_filters")
    ]

newtype ListServices = ListServices
    { _lsTimeZone' :: Maybe Text
    } deriving (Eq, Show)

instance Paginate ListServices

deriveJSON ''ListServices
makeLenses ''ListServices

-- | List existing services.
--
-- @GET \/services@
--
-- See: <http://developer.pagerduty.com/documentation/rest/services/list>
listServices :: Request ListServices Token [Service]
listServices = mk
    (path .~ "/services" & unwrap .~ key "escalation_policies" & query <>~ includes)
    ListServices
        { _lsTimeZone' = Nothing
        }

-- | Time zone in which dates in the result will be rendered.
-- Defaults to account default time zone.
lsTimeZone :: Lens' (Request ListServices s r) a
lsTimeZone = upd.lsTimeZone'

data CreateService = CreateService
    { _csName'                   :: Text
    , _csEscalationPolicyId'     :: PolicyId
    , _csType'                   :: !ServiceType
    , _csVendorId'               :: Maybe VendorId
    , _csDescription'            :: Maybe Text
    , _csAcknowledgementTimeout' :: Maybe Int
    , _csAutoResolveTimeout'     :: Maybe Int
    , _csSeverityFilter'         :: Maybe SeverityFilter
    } deriving (Eq, Show)

deriveJSON ''CreateService
makeLenses ''ListServices

-- | Creates a new service.
--
-- @POST \/services@
--
-- See: <http://developer.pagerduty.com/documentation/rest/services/create>
createService :: Text
              -> PolicyId
              -> ServiceType
              -> Request CreateService Token Service
createService n p t = mk
    (path .~ services & unwrap .~ key "service")
    CreateService
        { _csName'                   = n
        , _csEscalationPolicyId'     = p
        , _csType'                   = t
        , _csVendorId'               = Nothing
        , _csDescription'            = Nothing
        , _csAcknowledgementTimeout' = Nothing
        , _csAutoResolveTimeout'     = Nothing
        , _csSeverityFilter'         = Nothing
        }

-- | The name of the service.
csName :: Lens' (Request CreateService s r) a
csName = upd.csName'

-- | The id of the escalation policy to be used by this service.
csEscalationPolicyId :: Lens' (Request CreateService s r) a
csEscalationPolicyId = upd.csEscalationPolicyId'

-- | The type of service to create.
csType :: Lens' (Request CreateService s r) a
csType = upd.csType'

-- | PagerDuty's internal vendor identifier for this service. For more information
-- about a specific vendor, please contact PagerDuty Support.
csVendorId :: Lens' (Request CreateService s r) a
csVendorId = upd.csVendorId'

-- | A description for your service. 1024 character maximum.
csDescription :: Lens' (Request CreateService s r) a
csDescription = upd.csDescription'

-- | The duration in seconds before an incidents acknowledged in this service
-- become triggered again.
--
-- Defaults to 30 minutes.
csAcknowledgementTimeout :: Lens' (Request CreateService s r) a
csAcknowledgementTimeout = upd.csAcknowledgementTimeout'

-- | The duration in seconds before a triggered incident auto-resolves itself.
--
-- Defaults to 4 hours.
csAutoResolveTimeout :: Lens' (Request CreateService s r) a
csAutoResolveTimeout = upd.csAutoResolveTimeout'

-- | Specifies what severity levels will create a new open incident.
csSeverityFilter :: Lens' (Request CreateService s r) a
csSeverityFilter = upd.csSeverityFilter'

--
-- @GET services\/\:id@
--
-- See: <http://developer.pagerduty.com/documentation/rest/services/show>
getService = undefined

--
-- @PUT services\/\:id@
--
-- See: <http://developer.pagerduty.com/documentation/rest/services/update>
updateService = undefined

-- | Delete an existing service. Once the service is deleted, it will not be
-- accessible from the web UI and new incidents won't be able to be created
-- for this service.
--
-- @DELETE \/services/:id@
--
-- See: <http://developer.pagerduty.com/documentation/rest/services/delete>
deleteService :: ServiceId -> Request Empty Token Empty
deleteService i = mk (meth .~ DELETE & services [P i]) Empty

-- | Enable a previously disabled service.
--
-- @PUT services\/\:id\/enable@
--
-- See: <http://developer.pagerduty.com/documentation/rest/services/enable>
enableService :: ServiceId -> Request Empty Token Empty
enableService i = req PUT ("/services/", S i, "/enable") unwrap Empty

-- | Disable a service. Once a service is disabled, it will not be able to
-- create incidents until it is enabled again.
--
-- @PUT services\/\:id\/disable@
--
-- See: <http://developer.pagerduty.com/documentation/rest/services/disable>
disableService :: ServiceId -> Request Empty Token Empty
disableService i = req PUT (toByteString i <> "/disable") unwrap Empty

-- | Regenerate a new service key for an existing service.
--
-- _Warning! The service's previous key will be invalidated, and existing
-- monitoring integrations will need to be modified to use the new key!_
--
-- @POST services\/\:id\/regenerate_key@
--
-- See: <http://developer.pagerduty.com/documentation/rest/services/regenerate_key>
regenerateKey :: ServiceId -> Request Empty Token Service
regenerateKey i =
    req POST (toByteString i <> "/regenerate_key") unwrap Empty
