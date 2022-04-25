/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const recordManagement = require('./lib/recordManagement');

module.exports.recordManagement = recordManagement;
module.exports.contracts = [ recordManagement ];
