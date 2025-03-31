import unittest
from unittest.mock import MagicMock, patch
from modules.interface import MainInterface
from modules.database import Database
from modules.blockchain import BlockchainManager
import tkinter as tk
import tempfile
import os
import json

class TestBlockchainIntegration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Create temporary database
        cls.db_fd, cls.db_path = tempfile.mkstemp()
        cls.db = Database(cls.db_path)
        
        # Add test device
        cursor = cls.db.conn.cursor()
        cursor.execute("INSERT INTO devices VALUES (?, ?, ?)", 
                      ("TEST-001", "Cattle", "2023-01-01"))
        cls.db.conn.commit()

    @classmethod
    def tearDownClass(cls):
        os.close(cls.db_fd)
        os.unlink(cls.db_path)

    def setUp(self):
        # Mock blockchain components
        self.mock_bc = MagicMock(spec=BlockchainManager)
        self.mock_bc.connected = True
        self.mock_bc.record_life_event.return_value = "mock_tx_hash"
        self.mock_bc.generate_health_certificate.return_value = ("mock_cert_tx", "https://ipfs.io/mock_cert")
        self.mock_bc.transfer_ownership.return_value = "mock_transfer_tx"
        
        # Create root window
        self.root = tk.Tk()
        self.root.withdraw()  # Hide window during tests
        
        # Create interface with mocked components
        self.interface = MainInterface(
            root=self.root,
            db=self.db,
            camera=MagicMock(),
            blockchain=self.mock_bc
        )
        self.interface.current_device = "TEST-001"

    def tearDown(self):
        self.root.destroy()

    def test_life_event_recording(self):
        """Test complete life event recording workflow"""
        # Simulate UI actions
        self.interface.event_type.set("Vaccination")
        self.interface._record_life_event()
        
        # Verify blockchain was called
        self.mock_bc.record_life_event.assert_called_once_with(
            "TEST-001", "Vaccination"
        )
        
        # Verify database record
        cursor = self.db.conn.cursor()
        cursor.execute("SELECT * FROM life_events WHERE alpha_code=?", ("TEST-001",))
        result = cursor.fetchone()
        self.assertIsNotNone(result)
        self.assertEqual(result[1], "Vaccination")
        self.assertEqual(result[3], "mock_tx_hash")

    def test_certificate_generation(self):
        """Test complete certificate generation workflow"""
        # Simulate UI action
        self.interface._generate_certificate()
        
        # Verify blockchain was called
        self.mock_bc.generate_health_certificate.assert_called_once()
        
        # Verify database record
        cursor = self.db.conn.cursor()
        cursor.execute("SELECT * FROM certificates WHERE alpha_code=?", ("TEST-001",))
        result = cursor.fetchone()
        self.assertIsNotNone(result)
        self.assertEqual(result[2], "https://ipfs.io/mock_cert")

    def test_ownership_transfer(self):
        """Test complete ownership transfer workflow"""
        # Simulate UI actions
        self.interface.new_owner.set("0xNewOwner")
        self.interface._transfer_ownership()
        
        # Verify blockchain was called
        self.mock_bc.transfer_ownership.assert_called_once_with(
            "TEST-001", "0xNewOwner"
        )
        
        # Verify database record
        cursor = self.db.conn.cursor()
        cursor.execute("SELECT * FROM ownership WHERE alpha_code=?", ("TEST-001",))
        result = cursor.fetchone()
        self.assertIsNotNone(result)
        self.assertEqual(result[1], "0xNewOwner")

    def test_blockchain_disconnected(self):
        """Test behavior when blockchain is disconnected"""
        self.mock_bc.connected = False
        self.mock_bc.record_life_event.return_value = None
        
        # Simulate UI action
        self.interface.event_type.set("Vaccination")
        self.interface._record_life_event()
        
        # Verify no database record was created
        cursor = self.db.conn.cursor()
        cursor.execute("SELECT * FROM life_events WHERE alpha_code=?", ("TEST-001",))
        result = cursor.fetchone()
        self.assertIsNone(result)

if __name__ == '__main__':
    unittest.main()