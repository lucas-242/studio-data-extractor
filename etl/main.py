#!/usr/bin/env python3
"""
Main script to run ETL import processes.
First imports services and commissions, then Gendo 304 data.
"""

import sys
import os
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'lib'))

from import_gendo_services import main as import_gendo_services_and_commissions
from import_gendo_304 import main as import_gendo_304
from load_fact_sales import main as refresh_fact_sales
from config import CSV_PATHS


def main():
    print("🚀 Starting ETL processing...")
    print("=" * 50)
    
    try:
        print("📋 #1: Importing services...")
        services_file = CSV_PATHS["services"]
        
        if not os.path.exists(services_file):
            print(f"⚠️  Services file wasn't find: {services_file}")
        else:
            import_gendo_services_and_commissions()

        print("✅ #1 completed!")
        print()
        
        print("📊 #2: Importing Gendo 304 data...")
        import_gendo_304()
        print("✅ #2 completed!")
        print()

        print("📊 #3: Refreshing fact sales...")
        refresh_fact_sales()
        print("✅ #3 completed!")
        print()
        
        print("🎉 ETL processing completed!")
        
    except Exception as e:
        print(f"❌ Error processing ETL: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
