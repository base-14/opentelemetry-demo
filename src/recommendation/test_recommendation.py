#!/usr/bin/env python3
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

import unittest
from unittest.mock import MagicMock, patch
import grpc
from recommendation_server import RecommendationService


class TestRecommendationService(unittest.TestCase):
    def setUp(self):
        self.service = RecommendationService()

    def test_list_recommendations_empty_user_id(self):
        """Test that empty user_id returns empty recommendations"""
        request = MagicMock()
        request.user_id = ""
        context = MagicMock()
        
        response = self.service.ListRecommendations(request, context)
        
        self.assertEqual(len(response.product_ids), 0)

    def test_list_recommendations_valid_user_id(self):
        """Test that valid user_id returns recommendations"""
        request = MagicMock()
        request.user_id = "test_user"
        context = MagicMock()
        
        with patch('recommendation_server.get_product_list') as mock_get_products:
            mock_get_products.return_value = ["product1", "product2", "product3"]
            
            response = self.service.ListRecommendations(request, context)
            
            self.assertGreater(len(response.product_ids), 0)
            self.assertLessEqual(len(response.product_ids), 5)  # Max 5 recommendations

    @patch('recommendation_server.logger')
    def test_list_recommendations_logs_request(self, mock_logger):
        """Test that recommendations are logged"""
        request = MagicMock()
        request.user_id = "test_user"
        context = MagicMock()
        
        self.service.ListRecommendations(request, context)
        
        mock_logger.info.assert_called()


if __name__ == '__main__':
    unittest.main()