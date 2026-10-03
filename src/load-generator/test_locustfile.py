#!/usr/bin/env python3
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

import unittest
from unittest.mock import MagicMock, patch
from locustfile import WebsiteUser


def make_user():
    """FastHttpUser requires a base host at construction time."""
    with patch.object(WebsiteUser, "host", "http://localhost:8080"):
        return WebsiteUser(MagicMock())


class TestWebsiteUser(unittest.TestCase):
    def test_user_initialization(self):
        """Test that WebsiteUser can be initialized"""
        user = make_user()
        self.assertIsNotNone(user)

    def test_user_has_required_tasks(self):
        """Test that WebsiteUser has the required task methods"""
        user = make_user()

        # Check that the required methods exist
        self.assertTrue(hasattr(user, "index"))
        self.assertTrue(hasattr(user, "browse_product"))
        self.assertTrue(hasattr(user, "view_cart"))
        self.assertTrue(hasattr(user, "add_to_cart"))
        self.assertTrue(hasattr(user, "ask_agent"))

    @patch("locustfile.logging")
    def test_index_task_logs(self, mock_logging):
        """Test that index task logs appropriately"""
        user = make_user()
        user.client = MagicMock()

        user.index()

        mock_logging.info.assert_called_with("User accessing index page")
        user.client.get.assert_called_with("/")


if __name__ == "__main__":
    unittest.main()
