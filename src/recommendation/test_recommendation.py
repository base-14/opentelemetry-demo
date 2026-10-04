#!/usr/bin/env python3
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

import unittest
from unittest.mock import MagicMock, patch

import demo_pb2
import recommendation_server
from recommendation_server import RecommendationService

CATALOG_IDS = [f"PRODUCT{i}" for i in range(8)]


class TestRecommendationService(unittest.TestCase):
    def setUp(self):
        # These globals are only created when the server runs as __main__.
        self.catalog = MagicMock()
        self.catalog.ListProducts.return_value = demo_pb2.ListProductsResponse(
            products=[demo_pb2.Product(id=pid) for pid in CATALOG_IDS]
        )
        self.metrics = {"demo.recommendation.requests": MagicMock()}
        self.logger = MagicMock()
        module_globals = {
            "product_catalog_stub": self.catalog,
            "rec_svc_metrics": self.metrics,
            "logger": self.logger,
            "tracer": MagicMock(),
        }
        for name, value in module_globals.items():
            patcher = patch.object(recommendation_server, name, value, create=True)
            patcher.start()
            self.addCleanup(patcher.stop)

        flag = patch.object(
            recommendation_server, "check_feature_flag", return_value=False
        )
        self.check_feature_flag = flag.start()
        self.addCleanup(flag.stop)

        recommendation_server.cached_ids = []
        recommendation_server.first_run = True
        self.service = RecommendationService()

    def recommend(self, product_ids):
        request = demo_pb2.ListRecommendationsRequest(product_ids=product_ids)
        return list(self.service.ListRecommendations(request, MagicMock()).product_ids)

    def test_returns_at_most_five_catalog_products(self):
        recommended = self.recommend([])

        self.assertEqual(len(recommended), 5)
        self.assertEqual(len(set(recommended)), 5)
        self.assertTrue(set(recommended) <= set(CATALOG_IDS))

    def test_excludes_requested_product(self):
        for _ in range(20):
            self.assertNotIn("PRODUCT0", self.recommend(["PRODUCT0"]))

    def test_returns_remaining_products_when_fewer_than_five(self):
        self.catalog.ListProducts.return_value = demo_pb2.ListProductsResponse(
            products=[demo_pb2.Product(id="PRODUCT0"), demo_pb2.Product(id="PRODUCT1")]
        )

        recommended = self.recommend(["PRODUCT0"])

        self.assertEqual(recommended, ["PRODUCT1"])

    def test_records_request_metric_and_log(self):
        self.recommend([])

        self.metrics["demo.recommendation.requests"].add.assert_called_once_with(
            5, {"recommendation.type": "catalog"}
        )
        self.logger.info.assert_called_once()

    def test_cache_failure_flag_grows_cache_on_miss(self):
        self.check_feature_flag.return_value = True

        with patch.object(recommendation_server.random, "random", return_value=0.0):
            self.recommend([])
            size_after_first = len(recommendation_server.cached_ids)
            self.recommend([])

        self.assertEqual(size_after_first, 10)
        self.assertGreater(len(recommendation_server.cached_ids), size_after_first)


if __name__ == "__main__":
    unittest.main()
