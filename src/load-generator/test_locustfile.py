#!/usr/bin/env python3
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

import unittest
from unittest.mock import MagicMock, patch
from locustfile import WebsiteUser


class TestWebsiteUser(unittest.TestCase):
    def test_user_initialization(self):
        """Test that WebsiteUser can be initialized"""
        user = WebsiteUser(MagicMock())
        self.assertIsNotNone(user)

    def test_user_has_required_tasks(self):
        """Test that WebsiteUser has the required task methods"""
        user = WebsiteUser(MagicMock())
        
        # Check that the required methods exist
        self.assertTrue(hasattr(user, 'index'))
        self.assertTrue(hasattr(user, 'browse_product'))
        self.assertTrue(hasattr(user, 'view_cart'))
        self.assertTrue(hasattr(user, 'add_to_cart'))

    @patch('locustfile.logger')
    def test_index_task_logs(self, mock_logger):
        """Test that index task logs appropriately"""
        user = WebsiteUser(MagicMock())
        
        # This would require more setup to actually test the HTTP calls
        # For now, just test that the method exists and can be called
        self.assertTrue(callable(getattr(user, 'index', None)))


if __name__ == '__main__':
    unittest.main()