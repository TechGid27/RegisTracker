import { Outlet } from 'react-router-dom';
import { Box, Container } from '@mui/material';

import Header from '../../components/Header.jsx';

export default function Public() {
    return (
        <Box>
            <Header />
            <Outlet />
        </Box>
    );
}