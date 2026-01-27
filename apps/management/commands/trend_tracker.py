import pandas as pd
from django.core.management.base import BaseCommand

from apps.equities.models.equity import Equity
from apps.equities.models.lt_ob_zone import LtObZone
from apps.common.datelib import current_date
from apps.config.constants import Constants
from apps.equities.models.lt_td_position import LtTdPosition


class Command(BaseCommand):

    TEST = "My test Cmd"
    def handle(self, *args, **options):
        print(self.TEST)
        # language=MySQL
        # query = """
        #         SELECT ob.*, pos.value
        #         FROM lt_ob_zone AS ob
        #             INNER JOIN equity e ON (e.id = ob.equity_id AND e.instrument_type = %s)
        #                  INNER JOIN (SELECT td.equity_id, td.value, td.created_at \
        #                              FROM lt_td_position td \
        #                              WHERE td.id IN (SELECT MAX(id) \
        #                                             FROM lt_td_position \
        #                                             WHERE created_at < %s \
        #                                               AND position = %s AND deleted_at IS NULL GROUP BY equity_id)) AS pos
        #                             ON pos.equity_id = ob.equity_id
        #         WHERE pos.value BETWEEN (ob.zone_low - (ob.zone_low * %s)/100) AND (ob.zone_high + (ob.zone_high * %s)/100)
        #           AND ob.irl_type = %s
        #           AND ob.created_at < pos.created_at \
        #         """
        # params = ["EQ",current_date(), Constants.LOW, 1,1, Constants.BULLISH]
        # results = LtObZone.objects.raw(query, params)

        query = """
        SELECT pos.* FROM equity e 
                              INNER JOIN (SELECT td.id,td.equity_id, td.value, td.created_at  
                                          FROM lt_td_position td WHERE td.id IN 
                                                                       (SELECT MAX(id) FROM lt_td_position WHERE created_at < %s AND position = %s AND deleted_at IS NULL GROUP BY equity_id) ) pos 
                                         ON (pos.equity_id = e.id AND e.instrument_type = %s)
        """
        params = [current_date(), Constants.LOW, "EQ"]
        results = LtTdPosition.objects.raw(query, params)

        for obj in results:
            obZoneModel = LtObZone.objects.filter(
                equity_id = obj.equity_id,
                zone_high__gte = obj.value,
                zone_low__lte = obj.value
            ).order_by('-created_at')

            previousHighs = LtTdPosition.objects.filter(
                equity_id = obj.equity_id,
                position=Constants.HIGH
            ).order_by('-created_at').values('value','created_at')
            df = pd.DataFrame(previousHighs)
            highs = df['value']
            print(current_date())

